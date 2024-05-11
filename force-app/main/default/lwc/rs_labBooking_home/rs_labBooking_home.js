import { LightningElement } from 'lwc';

export default class Rs_labBooking_home extends LightningElement {
    // 实验室预约Tab激活
    handleAvailableBookingActive(event) {
        try {
            setTimeout(() => this.template.querySelector('c-rs_lab-booking_available-booking-list').getAvailableBookingList());
        } catch (error) {
            console.error("handleAvailableBookingActive Error -> ",error)
        }
    }

    handleMyBookingActive(event) {
        try {
            setTimeout(() => this.template.querySelector('c-rs_lab-booking_my-booking-list').getMyBookingList());
        } catch (error) {
            console.error("handleAvailableBookingActive Error -> ",error)
        }
    }
}