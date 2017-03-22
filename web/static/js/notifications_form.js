import toastr from 'toastr'

class NotificationsForm {
  constructor() {
    this.register_events()
  }

  register_events() {
    console.log("Registering NotificatinsForm events")
    $('body')
      .on('click', 'i[data-edit]', e => {
        let field = $(e.currentTarget).data('edit')
        this.push_userchan('edit', {field: field})
      })
      .on('click', 'i[data-play]', e => {
        console.log('play...')
      })
      .on('click', 'button.cancel', e => {
        this.push_userchan('cancel')
      })
      .on('click', 'button.save', e => {
        let params = $('.notifications form').serializeArray()
        this.push_userchan('save', params)
      })
  }
  push_userchan(action, params = {}) {
    userchan.push('notifications_form:' + action, params)
      .receive("ok", resp => {
        if (resp.html) {
          $('.content.notifications').replaceWith(resp.html)
        }
      })
      .receive("error", resp => {
        if (resp.error)
          toastr.error(resp.error)
      })
    }
}

$(document).ready(function() {
  new NotificationsForm()
})

export default NotificationsForm
