package sources.util.communication;


import sources.util.IabResult;

public interface BillingSupportCommunication {
    void onBillingSupportResult(int response);

    void remoteExceptionHappened(IabResult result);
}
