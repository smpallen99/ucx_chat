
// import * as flex_bar from './flex_bar'

// $(document).ready(function() {
//   $('body').on('click', 'a.toggle-favorite', e => {
//     e.preventDefault();
//     RoomManager.toggle_favorite()
//   })
//   $('body').on('click', '.button.pvt-msg', function(e) {
//     e.preventDefault();
//     RoomManager.add_private($(this))
//   })
// })

export function run() {
  update_mentions()
}
export function update_mentions() {
  let username = ucxchat.nickname;
  $(`.mention-link[data-username="${username}"]`).addClass('mention-link-me background-primary-action-color')
}
