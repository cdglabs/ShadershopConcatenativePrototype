ObjectManager = require("../persistence/ObjectManager")
Param = require("model/Param")
Apply = require("model/Apply")
ProvisionalApply = require("model/ProvisionalApply")
Block = require("model/Block")
Editor = require("model/Editor")


ObjectManager.registerClass("Param", Param)
ObjectManager.registerClass("Apply", Apply)
ObjectManager.registerClass("ProvisionalApply", ProvisionalApply)
ObjectManager.registerClass("Block", Block)
ObjectManager.registerClass("Editor", Editor)
require("./builtInFns")