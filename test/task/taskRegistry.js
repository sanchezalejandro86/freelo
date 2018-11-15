const TaskRegistry = artifacts.require("TaskRegistry");

contract('TaskRegistry', async ([_, owner]) => {
    let taskRegistry;

    beforeEach(async() => {
        taskRegistry = await TaskRegistry.new({from: owner});
    });

    describe('registry', function () {
        it('should have 0 tasks', async function () {
            const count = await taskRegistry.tasksLength();
            assert.equal(count, 0);
        });
    });

});