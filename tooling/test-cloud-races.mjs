import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
let sequence=0;
async function moduleWithFakeBackend(){
 const pending=[],saves=[];
 globalThis.sessionStorage={};
 globalThis.__clipboardTestClient={rpc(name,args){
  if(name==='save_business_workspace'){saves.push(args);return Promise.resolve({data:args.expected_revision+1,error:null});}
  return new Promise(resolve=>pending.push({args,resolve}));
 }};
 let source=await readFile(new URL('../web/cloud.js',import.meta.url),'utf8');
 source=source.replace("import {createClient} from './vendor/supabase.js';","const createClient=()=>globalThis.__clipboardTestClient;");
 const module=await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64')+'#'+sequence++);
 return {module,pending,saves};
}
const blank=()=>({items:[],sessions:[],expenses:[],settings:{}});
function resolve(pending,index,revision){pending[index].resolve({data:{state:blank(),revision},error:null});}
test('late business A load cannot overwrite business B revision',async()=>{
 const {module:m,pending,saves}=await moduleWithFakeBackend();
 const a=m.setBusiness({id:'A'});const rejected=assert.rejects(a,/business changed/);
 const b=m.setBusiness({id:'B'});resolve(pending,1,8);await b;
 resolve(pending,0,3);await rejected;
 await m.saveWorkspace(blank());assert.equal(saves[0].business,'B');assert.equal(saves[0].expected_revision,8);
});
test('a load completing after sign-out is discarded',async()=>{
 const {module:m,pending}=await moduleWithFakeBackend();
 const a=m.setBusiness({id:'A'});const rejected=assert.rejects(a,/business changed/);m.clearBusiness();resolve(pending,0,1);await rejected;assert.equal(m.currentBusiness(),null);
});
test('older reload cannot roll back a newer load in the same business',async()=>{
 const {module:m,pending,saves}=await moduleWithFakeBackend();
 const initial=m.setBusiness({id:'A'});resolve(pending,0,1);await initial;
 const old=m.loadWorkspace();const rejected=assert.rejects(old,/business changed/);const latest=m.loadWorkspace();
 resolve(pending,2,9);await latest;resolve(pending,1,2);await rejected;
 await m.saveWorkspace(blank());assert.equal(saves[0].expected_revision,9);
});
