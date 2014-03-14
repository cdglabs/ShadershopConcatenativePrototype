ObjectManager = require("../persistence/ObjectManager")
Param = require("model/Param")
Apply = require("model/Apply")
ProvisionalApply = require("model/ProvisionalApply")
Editor = require("model/Editor")


ObjectManager.registerClass("Param", Param)
ObjectManager.registerClass("Apply", Apply)
ObjectManager.registerClass("ProvisionalApply", ProvisionalApply)
ObjectManager.registerClass("Editor", Editor)
require("./builtInFns")