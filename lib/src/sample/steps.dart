// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class CreateItemStep extends Step {
  @override
  Future<WorkLog> doWork(WorkItem item, Process process) async {
    String itemName = process["itemName"];
    Guid itemId = new Guid();
    await process.publish(new CreateItem(itemId, itemName));
    return logWork("creating item [$itemName] with id $itemId", workLog:{"itemId":itemId});
  }

  @override
  Future<bool> compensate(WorkLog log, Process process) async {
    Guid itemId = log["itemId"];
    await process.publish(new RemoveItem(itemId, 0));
    return compensationSucceded("removing item [${process["itemName"]}] with id $itemId");
  }
}

class IncreaseInventoryStep extends Step {
  @override
  Future<WorkLog> doWork(WorkItem item, Process process) async {
    Guid itemId = process["itemId"];
    int itemCount = process["itemCount"];
    await process.publish(new IncreaseInventory(itemId, itemCount, 0));
    return logWork("increased inventory of item [${process["itemName"]}] to $itemCount");
  }

  @override
  Future<bool> compensate(WorkLog log, Process process) async {
    Guid itemId = process["itemId"];
    int itemCount = process["itemCount"];
    await process.publish(new DecreaseInventory(itemId, itemCount, 0));
    return compensationSucceded("decreased inventory of item [${process["itemName"]}] to $itemCount");
  }
}
