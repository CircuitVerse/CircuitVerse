// Algorithm used for Combinational Analysis

export default function BooleanMinimize(numVarsArg, minTermsArg, dontCaresArg = []) {
    let __result;

    Object.defineProperties(
        this, {
            minTerms: {
                value: minTermsArg,
                enumerable: false,
                writable: false,
                configurable: true,
            },

            dontCares: {
                value: dontCaresArg,
                enumerable: false,
                writable: false,
                configurable: true,
            },

            numVars: {
                value: numVarsArg,
                enumerable: false,
                writable: false,
                configurable: true,
            },

            result: {
                enumerable: true,
                configurable: true,
                get() {
                    if (__result === undefined) {
                        __result = BooleanMinimize.prototype.solve.call(this);
                    }

                    return __result;
                },
                set() {
                    throw new Error('result cannot be assigned a value');
                },
            },
        },
    );
}

BooleanMinimize.prototype.solve = function () {
    function dec_to_binary_string(n) {
        let str = n.toString(2);

        while (str.length != this.numVars) {
            str = `0${str}`;
        }

        return str;
    }

    function num_set_bits(s) {
        let ans = 0;
        for (let i = 0; i < s.length; ++i) { if (s[i] === '1') ans++; }
        return ans;
    }

    function get_prime_implicants(allTerms) {
        const table = [];
        const primeImplicants = new Set();
        let reduced;

        while (1) {
            for (let i = 0; i <= this.numVars; ++i) table[i] = new Set();
            for (let i = 0; i < allTerms.length; ++i) table[num_set_bits(allTerms[i])].add(allTerms[i]);

            allTerms = [];
            reduced = new Set();

            for (let i = 0; i < table.length - 1; ++i) {
                for (const str1 of table[i]) {
                    for (const str2 of table[i + 1]) {
                        let diff = -1;

                        for (let j = 0; j < this.numVars; ++j) {
                            if (str1[j] != str2[j]) {
                                if (diff === -1) {
                                    diff = j;
                                } else {
                                    diff = -1;
                                    break;
                                }
                            }
                        }

                        if (diff !== -1) {
                            allTerms.push(`${str1.slice(0, diff)}-${str1.slice(diff + 1)}`);
                            reduced.add(str1);
                            reduced.add(str2);
                        }
                    }
                }
            }

            for (const t of table) {
                for (const str of t) {
                    if (!(reduced.has(str))) primeImplicants.add(str);
                }
            }

            if (!reduced.size) break;
        }

        return primeImplicants;
    }

    function get_essential_prime_implicants(primeImplicants, minTerms) {
        const table = [];
        let column;

        function check_if_similar(minTerm, primeImplicant) {
            for (let i = 0; i < primeImplicant.length; ++i) {
                if (primeImplicant[i] !== '-' && (minTerm[i] !== primeImplicant[i])) return false;
            }

            return true;
        }

        function get_complexity(terms) {
            let complexity = terms.length;

            for (const t of terms) {
                for (let i = 0; i < t.length; ++i) {
                    if (t[i] !== '-') {
                        complexity++;
                        if (t[i] === '0') complexity++;
                    }
                }
            }

            return complexity;
        }

        function isSubset(sub, sup) {
            for (const i of sub) {
                if (!(sup.has(i))) return false;
            }

            return true;
        }

        for (const m of minTerms) {
            column = [];

            for (let i = 0; i < primeImplicants.length; ++i) {
                if (check_if_similar(m, primeImplicants[i])) {
                    column.push(i);
                }
            }

            table.push(column);
        }

        let possibleSets = [];
        let tempSets;

        for (const i of table[0]) {
            possibleSets.push(new Set([i]));
        }

        for (let i = 1; i < table.length; ++i) {
            tempSets = [];
            for (const s of possibleSets) {
                for (const p of table[i]) {
                    const x = new Set(s);
                    x.add(p);
                    let append = true;

                    for (let j = tempSets.length - 1; j >= 0; --j) {
                        if (isSubset(x, tempSets[j])) {
                            tempSets.splice(j, 1);
                        } else {
                            append = false;
                        }
                    }

                    if (append) {
                        tempSets.push(x);
                    }
                }

                possibleSets = tempSets;
            }
        }

        let essentialImplicants; let
            minComplexity = 1e9;

        for (const s of possibleSets) {
            const p = [];
            for (const i of s) {
                p.push(primeImplicants[i]);
            }
            const comp = get_complexity(p);
            if (comp < minComplexity) {
                essentialImplicants = p;
                minComplexity = comp;
            }
        }

        return essentialImplicants;
    }

    const minTerms = this.minTerms.map(dec_to_binary_string.bind(this));
    const dontCares = this.dontCares.map(dec_to_binary_string.bind(this));

    return get_essential_prime_implicants.call(
        this,
        Array.from(get_prime_implicants.call(this, minTerms.concat(dontCares))),
        minTerms,
    );
};
