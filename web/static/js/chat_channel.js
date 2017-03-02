export function push(message, args={}) {
  let base = {user_id: ucxchat.user_id, channel_id: ucxchat.channel_id, room: ucxchat.room}
  return roomchan.push(message, Object.assign(base, args));
}

export function delete_(route, args={}) {
  return do_push("delete", route, args)
}
export function post(route, args={}) {
  return do_push("post", route, args)
}
export function get(route, args={}) {
  return do_push("get", route, args)
}
export function new_(route, args={}) {
  return do_push("new", route, args)
}
export function edit(route, args={}) {
  return do_push("edit", route, args)
}
export function put(route, args={}) {
  return do_push("put", route, args)
}

export function do_push(verb, route, args={}) {
  return roomchan.push(route, {params: args, ucxchat: {assigns: base(), verb: verb}})
}

function base() {
  return {username: ucxchat.username, user_id: ucxchat.user_id, channel_id: ucxchat.channel_id, room: ucxchat.room}
}
