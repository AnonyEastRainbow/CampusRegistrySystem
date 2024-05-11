trigger RS_LeaveApplication_Trg on LeaveApplication__c (after update, before insert, before update) {
    new Triggers()
        .bind(Triggers.Evt.beforeinsert, new RS_Leave_Before_Hdl())
        .bind(Triggers.Evt.beforeupdate, new RS_Leave_Before_Hdl())
        .bind(Triggers.Evt.afterupdate, new RS_Leave_AfterUpdate_Hdl())
        .manage();
}