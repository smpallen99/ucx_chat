require('./chat_tooltip')
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
  .on('mouseenter','.reactions > li:not(.add-reaction)', (event) => {
    event.preventDefault()
    event.stopPropagation();
    UcxChat.tooltip.showElement($(event.currentTarget).find('.people').get(0), event.currentTarget);
  })

  .on('mouseleave', '.reactions > li:not(.add-reaction)', (event) => {
    event.preventDefault()
    event.stopPropagation();
    UcxChat.tooltip.hide();
  })
})

export function select(emoji, message_id) {
  chat_emoji.update_recent(emoji)
  userchan.push('reaction:select', {reaction: emoji, message_id: message_id})
}
