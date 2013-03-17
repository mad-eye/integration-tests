Meteor.startup ->
  bolideUrl = Meteor.settings.public.bolideUrl
  bolide =
    create: (name, callback)->
      Meteor.http.put "#{bolideUrl}/doc/#{name}", data: {type: "text2"}, callback

    modify: (name, version, ops, callback)->
      Meteor.http.post "#{bolideUrl}/doc/#{name}?v=#{version}", data: ops, callback

    set: (name, contents, callback)->
      version = bolide.snapshot(name).headers["x-ot-version"]
      #TODO delete something if its already there
      bolide.modify name, version, [contents], callback

    snapshot: (name, callback)->
      Meteor.http.get "#{bolideUrl}/doc/#{name}", {type: "text2"}, callback
