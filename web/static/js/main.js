
import * as flexbar from './flex_bar'

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
  update_flexbar()
  roomManager.updateMentionsMarksOfRoom()
}
export function update_mentions(id) {
  let username = ucxchat.username;
  let selector = `.mention-link[data-username="${username}"]`
  if (id)
    selector = '#' + id + ' ' + selector

  $(selector).addClass('mention-link-me background-primary-action-color')
}

export function update_flexbar() {
  flexbar.update_flexbar()
}

window.mentions = update_mentions

