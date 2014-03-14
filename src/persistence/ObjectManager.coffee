module.exports = ObjectManager = new class
  constructor: ->
    @idCounter_ = 0
    @classNames_ = {} # className: classConstructor
    @builtInObjects_ = {} # id : object

  assignId: (object) ->
    @idCounter_++
    id = "id-" + @idCounter_ + Date.now() + Math.floor(1e9 * Math.random())
    object.__id = id


  registerClass: (className, classConstructor) ->
    @classNames_[className] = classConstructor
    classConstructor.prototype.__className = className


  registerBuiltInObject: (id, object) ->
    @builtInObjects_[id] = object
    object.__id = id


  deconstruct: (object) ->
    objects = {} # id : object
    serialize = (object, force=false) =>
      if !force and id = object?.__id
        if !@builtInObjects_[id] and !objects[id]
          objects[id] = serialize(object, true)

        return {__ref: id}

      if _.isArray(object)
        result = []
        for entry in object
          result.push(serialize(entry))
        return result

      if _.isObject(object)
        result = {}
        for own key, value of object
          result[key] = serialize(value)
        if object.__className
          result.__className = object.__className
        return result

      return object ? null

    root = serialize(object)

    return {objects, root}


  reconstruct: ({objects, root}) ->
    # Construct all the objects

    constructedObjects = {} # id : object

    constructObject = (object) =>
      if className = object.__className
        classConstructor = @classNames_[className]
        constructedObject = new classConstructor()
        for own key, value of object
          if key != "__className"
            constructedObject[key] = value
        return constructedObject
      return object

    for own id, object of objects
      constructedObjects[id] = constructObject(object)

    root = constructObject(root)

    # Replace all {__ref} with the actual object

    derefObject = (object) =>
      return unless _.isObject(object)
      for own key, value of object
        if id = value?.__ref
          object[key] = @builtInObjects_[id] ? constructedObjects[id]
        else
          derefObject(value)

    for own id, object of constructedObjects
      derefObject(object)

    derefObject(root)

    return root


