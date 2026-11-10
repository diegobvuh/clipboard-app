import {build} from 'esbuild';
import {mkdir,writeFile,stat} from 'node:fs/promises';
const result=await build({stdin:{contents:"export {createClient} from '@supabase/supabase-js';",resolveDir:import.meta.dirname},bundle:true,format:'esm',platform:'browser',target:'es2022',minify:true,legalComments:'eof',write:false});
await mkdir(new URL('./vendor/',import.meta.url),{recursive:true});
await writeFile(new URL('./vendor/supabase.js',import.meta.url),result.outputFiles[0].contents);
const output=await stat(new URL('./vendor/supabase.js',import.meta.url));
if(output.size<1000)throw Error('Supabase browser bundle was not generated.');
console.log('Built Supabase browser bundle:',output.size,'bytes');
