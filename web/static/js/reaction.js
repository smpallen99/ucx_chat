$(document).ready(() => {
  $('body').on('click', '.reactions li.selected', e => {
    let emoji = ":" + $(e.currentTarget).data('emoji') + ":"
    let message_id = $(e.currentTarget).closest('li.message').attr('id')
    select(emoji, message_id)
  })
  .on('click', '.reactions li.add-reaction', e => {
    let message_id = $(e.currentTarget).closest('li.message').attr('id')
    chat_emoji.open_reactions(e.currentTarget, message_id)
  })
})

export function select(emoji, message_id) {
  userchan.push('reaction:select', {reaction: emoji, message_id: message_id})
}
