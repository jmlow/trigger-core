/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description coverage tests for the trigger dispatcher
 */
@isTest
private class TriggerDispatcherTest {
	private static TriggerHandler th = new TriggerHandler();

	@isTest private static void coverage_beforeInsert() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, true, false, true, false, false, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_afterInsert() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, false, true, true, false, false, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_beforeUpdate() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, true, false, false, true, false, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_afterUpdate() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, false, true, false, true, false, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_beforeDelete() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, true, false, false, false, true, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_afterDelete() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, false, true, false, false, true, false, 1, th);
		dispatcher.dispatch();
	}
	@isTest private static void coverage_afterUnDelete() {
		TriggerDispatcher dispatcher = new TriggerDispatcher(true, false, true, false, false, false, true, 1, th);
		dispatcher.dispatch();
	}
}
