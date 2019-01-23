public class Services.Notification : GLib.Object {
    public Notification () {}

    public void send_notification (Objects.Track track) {
        var notification = new GLib.Notification (track.title);
        notification.set_body (track.artist);
        notification.set_icon (GLib.Icon.new_for_string (track.cover));
        notification.set_priority (GLib.NotificationPriority.LOW);

        Application.instance.send_notification ("com.github.alainm23.byte", notification);
    }
}