trigger RS_TeachingSupplyBorrowing_Trg on TeachingSupplyBorrowingApplication__c (before insert, before update, after update) {
    new Triggers()
        .bind(Triggers.Evt.beforeinsert, new RS_TeachingSupply_Before_Hdl())
        .bind(Triggers.Evt.beforeupdate, new RS_TeachingSupply_Before_Hdl())
        .bind(Triggers.Evt.afterupdate, new RS_TeachingSupply_After_Hdl())
        .manage();
}