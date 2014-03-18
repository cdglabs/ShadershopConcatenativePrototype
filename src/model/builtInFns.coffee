Fn = require("./Fn")

constantFn = new Fn "", [null, 0],
  (a, b) -> "#{b}"

identityFn = new Fn "identity", [0],
  (a) -> "#{a}"


builtInFns = [
  constantFn
  new Fn "+", [0, 0],
    (a, b) -> "(#{a} + #{b})"
  new Fn "-", [0, 0],
    (a, b) -> "(#{a} - #{b})"
  new Fn "*", [1, 1],
    (a, b) -> "(#{a} * #{b})"
  new Fn "/", [1, 1],
    (a, b) -> "(#{a} / #{b})"
  new Fn "abs", [0],
    (a) -> "abs(#{a})"
  new Fn "sqrt", [0],
    (a) -> "sqrt(#{a})"
  new Fn "pow", [1, 1],
    (a, b) -> "pow(#{a}, #{b})"
  new Fn "sin", [0],
    (a) -> "sin(#{a})"
  new Fn "cos", [0],
    (a) -> "cos(#{a})"
  new Fn "fract", [0],
    (a) -> "fract(#{a})"
  new Fn "floor", [0],
    (a) -> "floor(#{a})"
  new Fn "ceil", [0],
    (a) -> "ceil(#{a})"
  new Fn "min", [0, 0],
    (a, b) -> "min(#{a}, #{b})"
  new Fn "max", [0, 0],
    (a, b) -> "max(#{a}, #{b})"
]


builtInFns.constantFn = constantFn
builtInFns.identityFn = identityFn

module.exports = builtInFns