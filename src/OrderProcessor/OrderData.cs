namespace ServiceBusToDatabase
{
    public class OrderData
    {
        public Guid OrderId { get; set; }
        public int CustomerId { get; set; }
        public List<OrderItem>? OrderItems { get; set; }
    }
}