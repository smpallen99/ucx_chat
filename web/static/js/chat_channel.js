export function push(message, args={}) {
  let base = {client_id: ucxchat.client_id, channel_id: ucxchat.channel_id, room: ucxchat.room}
  return roomchan.push(message, Object.assign(base, args));
}
