using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;

namespace ServiceBusToDatabase
{
    class Program
    {
        static async Task Main(string[] args)
        {
            string queueName = "website-orders";

            string? serviceBusConnectionString = Environment.GetEnvironmentVariable("SB_QUEUE_CONNECTION") ?? 
                throw new ArgumentNullException("Service Bus connection string must be supplied in environment variable SB_QUEUE_CONNECTION");

            Console.WriteLine(serviceBusConnectionString);

            await using var client = new ServiceBusClient(serviceBusConnectionString, new ServiceBusClientOptions{ TransportType = ServiceBusTransportType.AmqpTcp});
            var processor = client.CreateProcessor(queueName);

            processor.ProcessMessageAsync += ProcessMessageAsync;
            processor.ProcessErrorAsync += ProcessErrorAsync;

            await processor.StartProcessingAsync();

            Console.WriteLine("Listening for messages. Press any key to exit...");
            Console.ReadKey();

            await processor.StopProcessingAsync();
        }

        private static async Task ProcessMessageAsync(ProcessMessageEventArgs args)
        {
            string messageBody = args.Message.Body.ToString();
            Console.WriteLine($"Received message: {messageBody}");

            // Add your logic here to insert data into the database
            // For now, we'll just complete the message
            await args.CompleteMessageAsync(args.Message);
        }

        private static Task ProcessErrorAsync(ProcessErrorEventArgs args)
        {
            Console.WriteLine($"Error: {args.Exception.Message}");
            return Task.CompletedTask;
        }
    }
}
