package sources.util.communication;

public interface OnServiceConnectListener {
	void connected();

	void couldNotConnect();
}
