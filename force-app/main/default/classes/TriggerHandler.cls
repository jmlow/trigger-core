/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Base class for all trigger handlers. Provides default functionality
 * necessary for the dispatcher,which supports focus on implementation of only 
 * relevant functionality and business rules on each individual sObject
 */
public virtual without sharing class TriggerHandler {
	/**
	 * @description trigger context variables
	 */
	@TestVisible
	protected final List<SObject> sObjTriggerNew,sObjTriggerOld;
	@TestVisible
	protected final Map<Id,SObject> sObjNewMap,sObjOldMap;
	/**
	 * @description Constructor for injecting trigger variables -- useful
	 * for tests and such
	 */
	public TriggerHandler(List<SObject> triggerNew,List<SObject> triggerOld,
		Map<Id,SObject> newMap,Map<Id,SObject> oldMap) {
		this.sObjTriggerNew = triggerNew;
		this.sObjTriggerOld = triggerOld;
		this.sObjNewMap = newMap;
		this.sObjOldMap = oldMap;
	}
	/**
	 * @description whether or not the trigger is active. In this base class,it always 
	 * returns true to provide base functionality for those that don't want to implement
	 * trigger activation functionality. Child classes can override this if desired
	 * @return whether or not the trigger is active
	 */
	public virtual Boolean isTriggerActive() {
		Trigger_Kill_Switch__c killAllTriggers = Trigger_Kill_Switch__c.getValues('all');
		return killAllTriggers != null ? !killAllTriggers.Disable__c : true;
	}
	/**
	 * @description default do before Insert -- does nothing unless overriden by a child class
	 */
	public virtual void doBeforeInsert() {
		return;
	}
	/**
	 * @description default do before update -- does nothing unless overriden by a child class
	 */
	public virtual void doBeforeUpdate() {
		return;
	}
	/**
	 * @description default do before delete -- does nothing unless overriden by a child class
	 */
	public virtual void doBeforeDelete() {
		return;
	}
	/**
	 * @description default do after Insert -- does nothing unless overriden by a child class
	 */
	public virtual void doAfterInsert() {
		return;
	}
	/**
	 * @description default do after update -- does nothing unless overriden by a child class
		*/
	public virtual void doAfterUpdate() {
		return;
	}
	/**
	 * @description default do after delete -- does nothing unless overriden by a child class
	 */
	public virtual void doAfterDelete() {
		return;
	}
	/**
	 * @description default do after undelete -- does nothing unless overriden by a child class
	 */
	public virtual void doAfterUndelete() {
		return;
	}
}
