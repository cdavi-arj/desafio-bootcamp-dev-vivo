public class SendBirthdayEmailJob implements Queueable {
    public void execute(QueueableContext context) {
        BirthdayEmail.send();
    }
}