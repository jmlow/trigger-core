/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Centralized dispather which can be leveraged for any triggers
 * on any sObjects. 
 */
public with sharing class TriggerDispatcher {
	/**
	 * @description control logic variables for determining which trigger state is 
	 * currently being executed
	 */
	private Boolean isBefore, isAfter, isExecuting;
	private Boolean isInsert, isUpdate, isDelete, isUndelete;
	/**
	 * @description number of records being operated on
	 */
	private Integer size;
	/** 
	 * @description the custom trigger handler to be used
	 */
	private TriggerHandler handler;

	/**
	 * @description Standard constructor which sets all trigger dispatching related
	 * private variables
	 * @param isExecuting whether or not called from a trigger
	 * @param isBefore whether the current trigger context is a before trigger
	 * @param isAfter whether the current trigger context is an after trigger
	 * @param isInsert whether the current trigger context is for insert
	 * @param isUpdate whether the current trigger context is for update
	 * @param isDelete whether the current trigger context is for delete
	 * @param isUndelete whether the current trigger context is for undelete
	 * @param size the number of records being operated on
	 * @param handler TriggerHandler (or any child class of) which executes trigger business logic
	 */
	public TriggerDispatcher(
		Boolean isExecuting,
		Boolean isBefore,
		Boolean isAfter,
		Boolean isInsert,
		Boolean isUpdate,
		Boolean isDelete,
		Boolean isUndelete,
		Integer size,
		TriggerHandler handler
	) {
		this.isExecuting = isExecuting;
		this.isBefore = isBefore;
		this.isAfter = isAfter;
		this.isInsert = isInsert;
		this.isUpdate = isUpdate;
		this.isDelete = isDelete;
		this.isUndelete = isUndelete;
		this.size = size;
		this.handler = handler;
	}

	/**
	 * @description executes the appropriate handler methods based on the 
	 * current trigger context
	 */
	public void dispatch() {
		// if the trigger is not active -- do nothing
		// note that the trigger will always be active unless a child class overrides functionality
		if (!handler.isTriggerActive()) return;
		if (isBefore) {
			if (isInsert) {
				handler.doBeforeInsert();
			} else if (isUpdate) {
				handler.doBeforeUpdate();
			} else if (isDelete) {
				handler.doBeforeDelete();
			}
		} else if (isAfter) {
			if (isInsert) {
				handler.doAfterInsert();
			} else if (isUpdate) {
				handler.doAfterUpdate();
			} else if (isDelete) {
				handler.doAfterDelete();
			} else if (isUndelete) {
				handler.doAfterUndelete();
			}
		}
	}
}