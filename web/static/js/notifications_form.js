import toastr from 'toastr'

class NotificationsForm {
  constructor() {
    this.register_events()
  }

  register_events() {
    console.log("Registering NotificatinsForm events")
    $('body')
      .on('click', '.notifications i[data-edit]', e => {
        let field = $(e.currentTarget).data('edit')
        this.push_userchan('edit', {field: field})
      })
      .on('click', '.notifications i[data-play]', e => {
        console.log('play...')
        userchan.push('notifications_form:play')
          .receive("ok", resp => {
            if (resp.sound) {
              desktop_notifier.notify_audio(resp.sound)
            }
          })
      })
      .on('click', '.notifications button.cancel', e => {
        this.push_userchan('cancel')
      })
      .on('click', '.notifications button.save', e => {
        let params = $('.notifications form').serializeArray()
        this.push_userchan('save', params)
      })
      .on('change', 'select[name="notification[settings][audio]"]', e => {
        let sound = $(e.currentTarget).val()
        if (sound != 'none' && sound != 'system_default')
          $('#' + sound)[0].play()
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
