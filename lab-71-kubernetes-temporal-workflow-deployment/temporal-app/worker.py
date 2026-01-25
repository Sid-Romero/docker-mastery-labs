import asyncio
import temporalio.client
import temporalio.worker

from temporalio import activity, workflow

@activity.defn
async def get_greeting(name: str) -> str:
    return f"Hello, {name}!"

@workflow.defn
class GreetingWorkflow:
    @workflow.run
    async def run(self, name: str) -> str:
        return await temporalio.client.execute_activity(get_greeting, name, start_to_close_timeout=timedelta(seconds=5))


async def main():
    client = await temporalio.client.Client.connect("localhost:7233")

    worker = temporalio.worker.Worker(
        client,
        task_queue="my-task-queue",
        workflows=[GreetingWorkflow],
        activities=[get_greeting],
    )
    async with worker:
        print("Worker started, press Ctrl+C to exit")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())

from datetime import timedelta