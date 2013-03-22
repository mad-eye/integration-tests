bolide = {}
Meteor.startup ->
  bolideUrl = Meteor.settings.public.bolideUrl
  bolide =
    create: (name, callback)->
      Meteor.http.put "#{bolideUrl}/doc/#{name}", data: {type: "text2"}, (err, resp)->
        callback err, resp

    modify: (name, version, ops, callback)->
      Meteor.http.post "#{bolideUrl}/doc/#{name}?v=#{version}", data: ops, (err, resp)->
        callback err, resp

    set: (name, contents, callback)->
      bolide.snapshot name, (err, resp)->
        version = resp.headers["x-ot-version"]
        ops = []
        ops.push contents
        if resp.content.length > 0
          ops.push {d: resp.content.length}
        bolide.modify name, version, ops, (err, resp)->
          callback err, resp

    snapshot: (name, callback)->
      Meteor.http.get "#{bolideUrl}/doc/#{name}", {type: "text2"}, (err, resp)->
        callback err, resp