Fn = require("./Fn")


module.exports = [
  new Fn "", [null, 0],
    (a, b) -> "#{b}"
    (a, b) -> "#{b}"
  new Fn "+", [0, 0],
    (a, b) -> "(#{a} + #{b})"
    (a, b) -> "(#{a} + #{b})"
  new Fn "-", [0, 0],
    (a, b) -> "(#{a} - #{b})"
    (a, b) -> "(#{a} - #{b})"
  new Fn "*", [1, 1],
    (a, b) -> "(#{a} * #{b})"
    (a, b) -> "(#{a} * #{b})"
  new Fn "/", [1, 1],
    (a, b) -> "(#{a} / #{b})"
    (a, b) -> "(#{a} / #{b})"
  new Fn "abs", [0],
    (a) -> "Math.abs(#{a})"
    (a) -> "abs(#{a})"
  new Fn "sqrt", [0],
    (a) -> "Math.sqrt(#{a})"
    (a) -> "sqrt(#{a})"
  new Fn "pow", [1, 1],
    (a, b) -> "Math.pow(Math.abs(#{a}), #{b})"
    (a, b) -> "pow(#{a}, #{b})"
  new Fn "sin", [0],
    (a) -> "Math.sin(#{a})"
    (a) -> "sin(#{a})"
  new Fn "cos", [0],
    (a) -> "Math.cos(#{a})"
    (a) -> "cos(#{a})"
  new Fn "fract", [0],
    (a) -> "(#{a} - Math.floor(#{a}))"
    (a) -> "fract(#{a})"
  new Fn "floor", [0],
    (a) -> "Math.floor(#{a})"
    (a) -> "floor(#{a})"
  new Fn "ceil", [0],
    (a) -> "Math.ceil(#{a})"
    (a) -> "ceil(#{a})"
  new Fn "min", [0, 0],
    (a, b) -> "Math.min(#{a}, #{b})"
    (a, b) -> "min(#{a}, #{b})"
  new Fn "max", [0, 0],
    (a, b) -> "Math.max(#{a}, #{b})"
    (a, b) -> "max(#{a}, #{b})"
]