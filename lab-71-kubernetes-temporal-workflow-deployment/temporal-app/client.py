import asyncio
from temporalio import client


async def main():
    temporal_client = await client.Client.connect("localhost:7233")

    workflow = await temporal_client.start_workflow(
        "GreetingWorkflow",
        "World",
        id="my-workflow-id",
        task_queue="my-task-queue",
    )

    print(f"Workflow result: {await workflow.result()}")


if __name__ == "__main__":
    asyncio.run(main())