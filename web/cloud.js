import {createClient} from './vendor/supabase.js';
export const supabase=createClient('https://rgqnbtszblhtzgmnnchc.supabase.co','sb_publishable_Ons2NOHWU2x73BSRwQV2TQ_faI0eZby',{
 auth:{flowType:'pkce',persistSession:true,autoRefreshToken:true,detectSessionInUrl:true,storage:sessionStorage}
});
let active=null,revision=0,contextVersion=0,loadVersion=0;
export const currentBusiness=()=>active;
export const blankState=()=>({items:[],sessions:[],expenses:[],settings:{measurement:'When asked',voice:''}});
const check=({data,error})=>{if(error)throw error;return data};
export const rpc=async(name,args)=>check(await supabase.rpc(name,args));
export async function memberships(){return check(await supabase.from('businesses').select('id,name,depop_username,owner_id').order('created_at'));}
export async function setBusiness(business){contextVersion++;active=business;return loadWorkspace();}
export function clearBusiness(){contextVersion++;active=null;revision=0;}
export async function loadWorkspace(){if(!active)throw Error('Select a business first.');const businessId=active.id,context=contextVersion,load=++loadVersion;const data=await rpc('load_business_workspace',{business:businessId});const loaded=await hydrate(data.state);if(active?.id!==businessId||context!==contextVersion||load!==loadVersion)throw Error('The business changed while loading.');revision=data.revision;return loaded;}
async function signed(path){const data=check(await supabase.storage.from('garment-photos').createSignedUrl(path,60));return data.signedUrl;}
async function hydrate(data){
 const state=structuredClone(data);
 await Promise.all(state.items.flatMap(item=>(item.photos||[]).map(async photo=>{photo.src=await signed(photo.path);})));
 await Promise.all(state.sessions.flatMap(trip=>[
  ...(trip.receiptPath?[signed(trip.receiptPath).then(src=>{trip.receiptPhoto=src;})]:[]),
  ...trip.candidates.flatMap(c=>['photo','tag'].filter(key=>c[key+'Path']).map(async key=>{c[key]=await signed(c[key+'Path']);}))
 ]));
 return state;
}
async function uploadData(src,path,sourcePath){
 if(sourcePath){const blob=check(await supabase.storage.from('garment-photos').download(sourcePath));check(await supabase.storage.from('garment-photos').upload(path,blob,{contentType:blob.type,upsert:false,cacheControl:'60'}));return path;}
 if(!src?.startsWith('data:image/'))throw Error('Choose a JPEG, PNG or WebP photo again.');
 if(!src.startsWith('data:image/jpeg;base64,')){const original=await(await fetch(src)).blob();src=await compressPhoto(new File([original],'photo',{type:original.type}));}
 const blob=await(await fetch(src)).blob();
 if(blob.size>5242880)throw Error('This photo is too large. Choose a smaller photo.');
 check(await supabase.storage.from('garment-photos').upload(path,blob,{contentType:'image/jpeg',upsert:false,cacheControl:'60'}));
 return path;
}
export async function saveWorkspace(state){
 if(!active)throw Error('Select a business first.');
 const business=active.id,payload=structuredClone(state);
 // Uploaded paths are also retained in memory on failed saves, avoiding duplicate uploads on retry.
 for(let i=0;i<payload.items.length;i++){
  const item=payload.items[i];
  for(let j=0;j<(item.photos||[]).length;j++){
   const photo=item.photos[j],original=state.items[i].photos[j];
   if(!photo.path){photo.path=await uploadData(photo.src,`${business}/${item.id}/${crypto.randomUUID()}.jpg`,photo.sourcePath);original.path=photo.path;}
   delete photo.src;delete photo.sourcePath;
  }
 }
 for(let i=0;i<payload.sessions.length;i++){
  const trip=payload.sessions[i],original=state.sessions[i];
  if(trip.receiptPhoto&&!trip.receiptPath){trip.receiptPath=await uploadData(trip.receiptPhoto,`${business}/trips/${trip.id}/${crypto.randomUUID()}.jpg`);original.receiptPath=trip.receiptPath;}
  delete trip.receiptPhoto;
  for(let j=0;j<trip.candidates.length;j++)for(const key of ['photo','tag']){
   const candidate=trip.candidates[j],source=original.candidates[j];
   if(candidate[key]&&!candidate[key+'Path']){candidate[key+'Path']=await uploadData(candidate[key],`${business}/trips/${trip.id}/${crypto.randomUUID()}.jpg`);source[key+'Path']=candidate[key+'Path'];}
   delete candidate[key];
  }
 }
 const next=await rpc('save_business_workspace',{business,expected_revision:revision,payload});
 if(active?.id!==business)throw Error('The business changed during saving. Reload the workspace.');
 revision=next;
}

export async function generateDepopDraft(item){
 if(!item?.id)throw Error('Save the piece before generating a draft.');
 const photos=(item.photos||[]).filter(photo=>photo.path).slice(0,3).map(photo=>photo.path);
 const {data,error}=await supabase.functions.invoke('clipboard-api',{body:{action:'draft',item_id:item.id,photos}});
 if(error)throw error;
 if(!data?.draft)throw Error('The assistant did not return a draft.');
 return data;
}
export async function refreshImage(image,path){try{image.src=await signed(path);}catch{image.alt='Photo unavailable. Reload after checking your business access.';}}
export async function exportBusiness(){
 if(!active)throw Error('Choose a business first.');
 const data=await rpc('load_business_workspace',{business:active.id});
 const archive={format:'clipboard-business-export',version:1,exported_at:new Date().toISOString(),business:active,state:data.state};
 const blob=new Blob([JSON.stringify(archive,null,2)],{type:'application/json'}),url=URL.createObjectURL(blob);
 const link=document.createElement('a');link.href=url;link.download='clipboard-'+new Date().toISOString().slice(0,10)+'.json';link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
}
export async function compressPhoto(file){
 if(!['image/jpeg','image/png','image/webp'].includes(file.type))throw Error('Choose a JPEG, PNG or WebP image. Export HEIC photos as JPEG first.');
 if(file.size>20000000)throw Error('Choose a photo smaller than 20 MB.');
 const url=URL.createObjectURL(file);
 try{
  const image=new Image();image.src=url;await image.decode();
  const ratio=Math.min(1,1600/Math.max(image.naturalWidth,image.naturalHeight)),canvas=document.createElement('canvas');
  canvas.width=Math.round(image.naturalWidth*ratio);canvas.height=Math.round(image.naturalHeight*ratio);
  const ctx=canvas.getContext('2d');ctx.fillStyle='#fff';ctx.fillRect(0,0,canvas.width,canvas.height);ctx.drawImage(image,0,0,canvas.width,canvas.height);
  return canvas.toDataURL('image/jpeg',0.82);
 }finally{URL.revokeObjectURL(url);}
}
export async function readLegacyWorkspace(){
 if(indexedDB.databases && !(await indexedDB.databases()).some(database=>database.name==='clipboard-web'))return null;
 const database=await new Promise((resolve,reject)=>{const request=indexedDB.open('clipboard-web');request.onupgradeneeded=()=>request.transaction.abort();request.onsuccess=()=>resolve(request.result);request.onerror=()=>reject(Error('No older browser workspace was found.'));});
 try{return await new Promise((resolve,reject)=>{if(!database.objectStoreNames.contains('data'))return resolve(null);const request=database.transaction('data').objectStore('data').get('state');request.onsuccess=()=>resolve(request.result||null);request.onerror=()=>reject(request.error);});}finally{database.close();}
}
