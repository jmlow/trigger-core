# Trigger Core Architecture
One of the key challenges that software developers face is writing clean, reusable, DRY (Don't Repeat Yourself) code in a way that is maintainable and extensible. As such, a significant amount of effort is focused on developing design patterns around those objectives. One such pattern is the centralized trigger dispatcher.

Before diving into the details of the pattern itself, it is useful to understand the context of why such a pattern might be useful. To begin, let's examine the worst possible situation. Consider a strategy where one might implement a standard of one trigger per business rule. While this might make sense from an SRP (single responsibility principle) perspective, it is easy to see how this approach doesn't scale. Business rules can often be numerous and complex, and only having a single business rule per trigger would easily impose many separate trigger files for the same sObject. The many disparate files would make things hard to maintain, and if functionality were to be added (such as logging and monitoring), all of those many files would need to be updated as well. This clearly makes the solution not extensible.

Now let's examine a more reasonable solution. It has been decided that triggers should be consolidated, with some amount of logic to determine which business rules should be applied. This addresses the issue of maintenance and extensibility to some degree, as now changes can happen in a single place. One of the key flaws with the solution as is, is that it is probably not very testable. Rather than being able to apply true unit-testing principles, several business rules would be tested at the same time, implying more of an integration testing strategy which may make it difficult to identify bugs (without the help of unit tests). To satisfy this, business rules are moved into a service class — a class with static methods which handles business logic. Now, the service class can be unit-tested, and the dispatcher can call the appropriate service class methods.

While the above solution is significantly better than the first, it does still have on problem — it requires that the entire suite of files described must be created for EACH sObject. This means a lot of boilerplate, and worse still, it means if you wanted to include global functionality (once again, logging and monitoring), you would need to do it in the collection of files pertaining to each sObject. As such, the design pattern described in the remainder of this README attempts to alleviate those concerns, while providing a mechanism that can easily scale in terms of complexity, file and code size, testing,  and development time.

# Trigger Dispatcher

At the core of the dispatcher design pattern is the dispatcher itself. The code provided below is generic, and can be reused as a basis for most (if not all) applications. 

```
/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Centralized dispatcher which can be leveraged for any trigger
 * on any sObject. 
 */
public without sharing class TriggerDispatcher {
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
     * @param isBefore whether the current trigger context is a before trigger
     * @param isAfter whether the current trigger context is an after trigger
     * @param isExecuting whether or not called from a trigger
     * @param isInsert whether the current trigger context is for insert
     * @param isUpdate whether the current trigger context is for update
     * @param isDelete whether the current trigger context is for delete
     * @param isUndelete whether the current trigger context is for undelete
     * @param size the number of records being operated on
     * @param handler TriggerHandler (or any child class of) which executes 
     * trigger business logic
     */
    public TriggerDispatcher(
        Boolean isBefore,
        Boolean isAfter,
        Boolean isExecuting,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete,
        Integer size,
        TriggerHandler handler
    ) {
        this.isBefore = isBefore;
        this.isAfter = isAfter;
        this.isExecuting = isExecuting;
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
        // note that the trigger will always be active unless a child class 
        // overrides functionality
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
```

As can be seen, it is fairly straight-forward. The dispatcher accepts in all necessary trigger context fields for routing, as well as a TriggerHandler (Described later) class instance to handle all business logic. Note that the TriggerHandler argument, via polymorphism, will also work with any child class which extends the TriggerHandler class. It will evaluate the trigger context variables, and call the according handler methods.

# Trigger Handlers

One of the key objectives of this design pattern is to minimize boilerplate code as the number of sObjects which require trigger logic scales. Given that context, below is the base TriggerHandler class which will be used to inform all other trigger handler classes. 

```
/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Base class for all trigger handlers. Provides default functionality
 * necessary for the dispatcher, which supports focus on implementation of only 
 * relevant functionality and business rules on each individual sObject
 */
public virtual without sharing class TriggerHandler {
    /**
    * @description trigger context variables
    */
    @TestVisible
    protected List<SObject> triggerNew, triggerOld;
    @TestVisible
    protected Map<Id, SObject> newMap, oldMap;
    /**
     * @description Sets the the trigger variables if in a trigger context
     */
    public TriggerHandler() {
        // If in a trigger context, store the trigger variable
        if (Trigger.isExecuting) {
            this.triggerNew = Trigger.new;
            this.triggerOld = Trigger.old;
            this.newMap = Trigger.newMap;
            this.oldMap = Trigger.oldMap;
        }
    }
    /**
     * @description Constructor for injecting trigger variables -- useful
     * for tests and such    
     */
    public TriggerHandler(List<SObject> triggerNew, List<SObject> triggerOld,
            Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        this.triggerNew = triggerNew;
        this.triggerOld = triggerOld;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    /**
     * @description whether or not the trigger is active. In this base class, it always 
     * returns true to provide base functionality for those that don't want to implement
     * trigger activation functionality. Child classes can override this if desired
     * @return whether or not the trigger is active
     */
    public virtual Boolean isTriggerActive() {
        return true;
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
    
    public List<SObject> getTriggerNew() { return this.triggerNew; }
    public List<SObject> getTriggerOld() { return this.triggerOld; }
    public Map<Id, SObject> getNewMap() { return this.newMap; }
    public Map<Id, SObject> getOldMap() { return this.oldMap; }
    public void setTriggerNew(List<SObject> triggerNew) { this.triggerNew = triggerNew; }
    public void setTriggerOld(List<SObject> triggerOld) { this.triggerOld = triggerOld; }
    public void setNewMap(Map<Id, SObject> newMap) { this.newMap = newMap; }
    public void setOldMap(Map<Id, SObject> oldMap) { this.oldMap = oldMap; }
}
```

As can be seen, the TriggerHandler class has members which are deemed common to all trigger applications.  Additionally, it provides the interface for which the TriggerDispatcher defined above interacts with. Note that all of the methods leveraged by the dispatcher do nothing in this base class. This is to ensure that child classes only have to implement the minimum amount of code necessary to work with the dispatcher.

With all of the above defined, we have successfully implemented all of the boilerplate necessary for this design pattern. We can now quite easily add new trigger handlers. As an example, refer to the following class:

```
/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Example implementation of a trigger handler
 */
public without sharing class AccountTriggerHandler extends TriggerHandler {
    /**
     * @description Standard constructor -- sets class variables
     */
    public AccountTriggerHandler() {
        super();
    }

    // Note that we only have to override the 2 methods from the parent that we care about
    public override void doBeforeInsert() {
        checkMatchBillingAddress();
    }

    public override void doBeforeUpdate() {
        checkMatchBillingAddress();
    }

    // These can be contained within the class, or in a service class
    // if there is no need to reuse, it might makes more sense to capture everything
    // within this handler class
    /**
     * @description checks if the shipping address should be the same as the billing address
     */
    @TestVisible
    private void checkMatchBillingAddress() {
        // casting can be avoided using the sObject get/put methods
        for (Account a : (List<Account>) this.triggerNew) {
            if (a.Match_Billing_Address__c == true && a.BillingPostalCode != null) {
                a.ShippingPostalCode = a.BillingPostalCode;
            }
        }
    }
}
```

This child class leans on the parent constructor for initialization, and only overrides the key trigger cases which are pertinent to the business logic of the Account object. In this instance, the business logic methods are private methods within the class. While it makes sense to encapsulate business logic, if the necessity to reuse business logic in other applications arises, then it can be moved out into a service class.

# Putting it all together

The previously discussed components provide the majority of functionality for the centralized trigger dispatcher. To tie everything together, the final missing piece is hooking in all of the components in the trigger itself. The following trigger code shows an example of how the above can be utilized:

```
/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Example Trigger created using the above classes.
 */
 trigger AccountTrigger on Account (before insert, before update, before delete,
        after insert, after update, after delete) {
    TriggerHandler handler = new AccountTriggerHandler();
    TriggerDispatcher dispatcher = new TriggerDispatcher(
        Trigger.isBefore,
        Trigger.isAfter,
        Trigger.isExecuting,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete,
        Trigger.size,
        handler
    );
    dispatcher.dispatch();
}
```

The steps to hooking everything together involve creating a new TriggerHandler, which is then passed to the TriggerDispatcher. Finally, the dispatch method if called to execute the appropriate trigger logic. At this point, adding any additional business rules for an Account sObject via trigger can be done by editing the AccountTriggerHandler class, and nothing else.
