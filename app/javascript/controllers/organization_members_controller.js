import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $('#org_member_emails').select2({
      tags: true,
      multiple: true,
      tokenSeparators: [',', ' '],
      dropdownParent: $('#inviteMemberModal'),
    });
    $('#inviteMemberModal .select2-selection input').attr('maxlength', '30');
  }
}
