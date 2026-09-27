import { Controller } from 'stimulus';
import { initEmailTagSelect } from '../utils/emailTagSelect';

export default class extends Controller {
    connect() {
        $('#promote-member-modal').on('show.bs.modal', (e) => {
            const groupmember = $(e.relatedTarget).data('currentgroupmember');
            $(e.currentTarget).find('#groups-member-promote-button').parent().attr('action',
                `/group_members/${groupmember.toString()}`);
        });
        $('#demote-member-modal').on('show.bs.modal', (e) => {
            const groupmember = $(e.relatedTarget).data('currentgroupmember');
            $(e.currentTarget).find('#groups-member-demote-button').parent().attr('action',
                `/group_members/${groupmember.toString()}`);
        });
    }

    addMentorToGroup() {
        initEmailTagSelect('#group_mentor_emails', {
            onChange: (count) => {
                $('#add-mentor-button').attr('disabled', count === 0);
            },
        });
    }

    addMemberToGroup() {
        initEmailTagSelect('#group_member_emails', {
            onChange: (count) => {
                $('#add-members-button').attr('disabled', count === 0);
            },
        });
    }
}
