trigger RS_LabBookingApplication_Trg on LabBookingApplication__c (before insert, before update, after update) {
    new Triggers()
        .bind(Triggers.Evt.beforeinsert, new RS_LabBookingApplication_Before_Hdl())
        .bind(Triggers.Evt.beforeupdate, new RS_LabBookingApplication_Before_Hdl())
        .bind(Triggers.Evt.afterupdate, new RS_LabBookingApplication_After_Hdl())
        .manage();
}