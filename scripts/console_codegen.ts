// Tool to generate source and tests for utils/console.sol

// Usage:
// npx ts-node scripts/console_codegen.ts [NUMBER_OF_PARAMS] (GENERATE_TESTS true | false (default))

interface paramInfo {
  type: string
  implementation: string
  testVariableName: string
}

const supportedTypes: Array<paramInfo> = [
  { type: 'uint256', implementation: '$paramName', testVariableName: 'u' },
  { type: 'int256', implementation: 'itoa($paramName)', testVariableName: 'i' },
  { type: 'address', implementation: '$paramName', testVariableName: 'a' },
  { type: 'bool', implementation: '$paramName', testVariableName: 'b' },
  { type: 'UFixed6', implementation: 'ftoa(UFixed6.unwrap($paramName), 6)', testVariableName: 'uf6' },
  { type: 'UFixed18', implementation: 'ftoa(UFixed18.unwrap($paramName), 18)', testVariableName: 'uf18' },
  { type: 'Fixed6', implementation: 'ftoa(Fixed6.unwrap($paramName), 6)', testVariableName: 'f6' },
  { type: 'Fixed18', implementation: 'ftoa(Fixed18.unwrap($paramName), 18)', testVariableName: 'f18' },
]

function generateCombinationsWithRepetition(n: number, p: number): number[][] {
  const results: number[][] = []

  function combine(current: number[], depth: number): void {
    if (depth === n) {
      results.push(current)
      return
    }

    for (let i = 0; i < p; i++) {
      combine([...current, i], depth + 1)
    }
  }

  combine([], 0)
  return results
}

function buildPermutations(numParams: number, generateTests = false): string {
  const combinations = generateCombinationsWithRepetition(numParams, supportedTypes.length)
  let retval = ''
  for (const combination of combinations) {
    if (generateTests) {
      retval += generateTest(combination)
    } else {
      retval += generateFunction(combination)
    }
  }
  console.log(`    // generated ${combinations.length} permutations\n`)
  return retval
}

function generateFunction(permutation: Array<number>): string {
  // function prototype
  let paramList = ''
  for (let i = 0; i < permutation.length; i++) {
    paramList += `${supportedTypes[permutation[i]].type} p${i + 1}`
    if (i < permutation.length - 1) paramList += ', '
  }
  let retval = `    function log(string memory p0, ${paramList}) internal view {\n`

  // implementation
  let implementationList = ''
  for (let i = 0; i < permutation.length; i++) {
    implementationList += supportedTypes[permutation[i]].implementation.replace('$paramName', `p${i + 1}`)
    if (i < permutation.length - 1) implementationList += ', '
  }
  retval += `        hhConsole.log(p0, ${implementationList});\n`

  // function closing and trailing newline
  retval += '    }\n\n'
  return retval
}

function generateTest(permutation: Array<number>): string {
  let paramList = '' // labeled components of the format string
  let variableList = '' // corresponding variables
  for (let i = 0; i < permutation.length; i++) {
    paramList += `${supportedTypes[permutation[i]].type} %s`
    variableList += `${supportedTypes[permutation[i]].testVariableName}`
    if (i < permutation.length - 2) {
      paramList += ', '
      variableList += ', '
    } else if (i < permutation.length - 1) {
      paramList += ' and '
      variableList += ', '
    }
  }
  return `        console.log("      ${paramList}", ${variableList});\n`
}

const numberParamsArg = process.argv.slice(2)[0]
const generateTestsArg = process.argv.slice(2)[1]
const numberParams = numberParamsArg ? Number.parseInt(numberParamsArg) : 2
const output = buildPermutations(numberParams, generateTestsArg === 'true')
console.log(output)
