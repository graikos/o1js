import { Field, ZkProgram, Cache, verify } from 'o1js';

let MyProgram = ZkProgram({
  name: 'example-with-output',
  publicOutput: Field,
  methods: {
    baseCase: {
      privateInputs: [],
      async method() {
        return {
          publicOutput: Field(1),
        };
      },
    },
  },
});

const cache = Cache.FileSystem('/tmp/o1js/cache', true); // <- debug on

console.time('compile (with cache)');
let { verificationKey } = await MyProgram.compile({ cache });
console.timeEnd('compile (with cache)');

console.time('proving 1');
let result = await MyProgram.baseCase();
console.timeEnd('proving 1');

console.time('proving 2');
let result2 = await MyProgram.baseCase();
console.timeEnd('proving 2');

console.log('verifying');
let ok = await verify(result.proof, verificationKey);
console.log('ok', ok);
