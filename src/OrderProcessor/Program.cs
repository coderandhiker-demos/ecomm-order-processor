using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.Json;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;

namespace ServiceBusToDatabase
{
    class Program
    {
        static async Task Main(string[] args)
        {
            string queueName = "website-orders";

            string serviceBusConnectionString = Environment.GetEnvironmentVariable("SB_QUEUE_CONNECTION") ??
                throw new ArgumentNullException("Service Bus connection string must be supplied in environment variable SB_QUEUE_CONNECTION");

            string sqlConnectionString = Environment.GetEnvironmentVariable("DB_CONNECTION") ??
                throw new ArgumentNullException("SQL Database connection string must be supplied in environment variable DB_CONNECTION");

            await using var client = new ServiceBusClient(serviceBusConnectionString);
            var processor = client.CreateProcessor(queueName);

            processor.ProcessMessageAsync += async args =>
            {
                string messageBody = args.Message.Body.ToString();
                Console.WriteLine($"Received message: {messageBody}");

                // Insert the order into the database
                Guid? newOrderGuid = await InsertOrderIntoDatabase(sqlConnectionString, messageBody);
                if (newOrderGuid.HasValue)
                {
                    Console.WriteLine($"New Order ID: {newOrderGuid}");
                }

                await args.CompleteMessageAsync(args.Message);
            };

            processor.ProcessErrorAsync += ProcessErrorAsync;

            await processor.StartProcessingAsync();

            Console.WriteLine("Listening for messages. Press any key to exit...");
            Console.Read();

            await processor.StopProcessingAsync();
        }

        private static Task ProcessErrorAsync(ProcessErrorEventArgs args)
        {
            Console.WriteLine($"Error: {args.Exception.Message}");
            return Task.CompletedTask;
        }

        private static async Task<Guid?> InsertOrderIntoDatabase(string sqlConnectionString, string orderJson)
        {
            using var connection = new SqlConnection(sqlConnectionString);
            await connection.OpenAsync();

            var orderData = JsonSerializer.Deserialize<OrderData>(orderJson);

            using var transaction = connection.BeginTransaction();

            try
            {
                Guid? newOrderGuid = null;

                using (var insertOrderCommand = new SqlCommand(
                    "INSERT INTO Orders (CustomerID, OrderDate) OUTPUT inserted.OrderID VALUES (@CustomerID, @OrderDate)",
                    connection,
                    transaction))
                {
                    insertOrderCommand.Parameters.AddWithValue("@CustomerID", orderData?.CustomerId);
                    insertOrderCommand.Parameters.AddWithValue("@OrderDate", DateTime.Now);
                    var result = await insertOrderCommand.ExecuteScalarAsync();

                    if (result != null && result != DBNull.Value)
                    {
                        newOrderGuid = (Guid)result;
                    }
                }
                
                foreach (var item in orderData?.OrderItems ?? Enumerable.Empty<OrderItem>())
                {
                    using var insertOrderItemCommand = new SqlCommand(
                        "INSERT INTO OrderItems (OrderID, ProductID, Quantity) VALUES (@OrderID, @ProductID, @Quantity)",
                        connection,
                        transaction);
                    
                    insertOrderItemCommand.Parameters.AddWithValue("@OrderID", newOrderGuid);
                    insertOrderItemCommand.Parameters.AddWithValue("@ProductID", item.ProductId);
                    insertOrderItemCommand.Parameters.AddWithValue("@Quantity", item.Quantity);
                    await insertOrderItemCommand.ExecuteNonQueryAsync();
                    Console.WriteLine($"{item.Quantity} of ProductID {item.ProductId} purchased");
                }

                transaction.Commit();

                return newOrderGuid;
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                throw ex;
            }
        }
    }
}
