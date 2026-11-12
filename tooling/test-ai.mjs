import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {transform} from '../web/node_modules/esbuild/lib/main.js';
const source=await readFile(new URL('../supabase/functions/clipboard-api/index.ts',import.meta.url),'utf8');
const built=await transform(source,{loader:'ts',format:'esm',target:'es2022'});
const {createHandler}=await import('data:text/javascript;base64,'+Buffer.from(built.code).toString('base64'));
const business='11111111-1111-4111-8111-111111111111',item='22222222-2222-4222-8222-222222222222',path=`${business}/${item}/photo.jpg`;
const json=(body,status=200)=>new Response(JSON.stringify(body),{status,headers:{'content-type':'application/json'}});
function fixture({access=true,provider=true,output=null}={}){
 let calls=[];const fetch=async(url,options={})=>{calls.push({url,options});
  if(url.endsWith('/auth/v1/user'))return json({id:'33333333-3333-4333-8333-333333333333',email_confirmed_at:'yes'});
  if(url.endsWith('/rpc/load_business_workspace'))return access?json({revision:4,state:{items:[{id:item,name:'Jacket',photos:[{path}]}],sessions:[],expenses:[],settings:{measurement:'When asked'}}}):json({},403);
  if(url.includes('/rest/v1/businesses?'))return json([{ai_enabled:true}]);
  if(url.includes('/storage/v1/object/sign/'))return json({signedURL:'/object/sign/garment-photos/'+path+'?token=hidden'});
  if(url.endsWith('/rpc/reserve_ai_pilot'))return json({remaining_cents:1990});
  if(url==='https://api.openai.com/v1/responses')return provider?json({output:[{content:[{type:'output_text',text:JSON.stringify(output||{title:'Jacket',description:'A jacket',brand:'',size:'',category:'',condition:'',check:['Confirm size']})}]}]}):json({},429);
  throw Error('Unexpected request '+url);
 };
 return {handler:createHandler({fetch,env:key=>({OPENAI_API_KEY:'test',SUPABASE_SERVICE_ROLE_KEY:'test'})[key]}),calls};
}
const request=body=>new Request('https://edge.test',{method:'POST',headers:{authorization:'Bearer token','content-type':'application/json'},body:JSON.stringify(body)});
test('draft reads authorized workspace and returns a separate structured suggestion',async()=>{const {handler,calls}=fixture();const res=await handler(request({action:'draft',business_id:business,item_id:item,photos:[path]}));assert.equal(res.status,200);assert.equal((await res.json()).draft.title,'Jacket');assert.ok(calls.some(x=>x.url.endsWith('/rpc/load_business_workspace')));assert.ok(!calls.some(x=>x.url.includes('save_business_workspace')));});
test('foreign photo is rejected before provider or quota use',async()=>{const {handler,calls}=fixture();const res=await handler(request({action:'draft',business_id:business,item_id:item,photos:['other/path']}));assert.equal(res.status,400);assert.ok(!calls.some(x=>x.url.includes('reserve_ai_pilot')||x.url.includes('openai.com')));});
test('outsider cannot access workspace or invoke provider',async()=>{const {handler,calls}=fixture({access:false});const res=await handler(request({action:'chat',business_id:business,message:'What is in stock?'}));assert.equal(res.status,403);assert.ok(!calls.some(x=>x.url.includes('openai.com')));});
test('provider failure is surfaced without leaking details',async()=>{const {handler}=fixture({provider:false});const res=await handler(request({action:'chat',business_id:business,message:'What is in stock?'}));assert.equal(res.status,502);assert.match((await res.json()).error,/could not complete/);});

test('chat returns only allowed proposals tied to the authorized workspace',async()=>{const {handler}=fixture({output:{answer:'Here is a suggestion.',proposals:[{item_id:item,field:'name',value:'Vintage jacket',reason:'Clearer'},{item_id:item,field:'status',value:'Sold',reason:'Invalid'},{item_id:'44444444-4444-4444-8444-444444444444',field:'name',value:'Other',reason:'Foreign'}]}});const res=await handler(request({action:'chat',business_id:business,message:'Suggest a new title'}));const result=await res.json();assert.equal(res.status,200);assert.equal(result.proposals.length,1);assert.equal(result.proposals[0].field,'name');});
