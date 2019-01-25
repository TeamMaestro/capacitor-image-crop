package co.fitcom.capacitor;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.getcapacitor.AndroidProtocolHandler;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.yalantis.ucrop.UCrop;
import com.getcapacitor.FileUtils;

import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;


@NativePlugin(
        requestCodes = {UCrop.REQUEST_CROP}
)
public class ImageCropPlugin extends Plugin {

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);

        PluginCall savedCall = getSavedCall();

        if (savedCall == null) {
            return;
        }


        if (resultCode == Activity.RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
            final Uri resultUri = UCrop.getOutput(data);
            JSObject object = new JSObject();
            object.put("value", FileUtils.getPortablePath(getContext(), bridge.getLocalUrl(), resultUri));
            savedCall.resolve(object);
        } else if (resultCode == UCrop.RESULT_ERROR) {
            final Throwable cropError = UCrop.getError(data);
            savedCall.reject(cropError.getLocalizedMessage());
        }
    }

    @PluginMethod()
    public void show(PluginCall call) {
        String source = call.getString("source");
        int width = call.getInt("width");
        int height = call.getInt("height");
        File dest = new File(getActivity().getCacheDir().getAbsolutePath() + "/CAP_CROP.jpg");
        boolean isAppPath = false;
        if (source.contains("~")) {
            isAppPath = true;
            source = source.replace("~", "");
        }

        AndroidProtocolHandler protocolHandler = new AndroidProtocolHandler(getActivity().getApplicationContext());
        try {
            File tempSource;
            if (isAppPath) {
                File f = new File("file:///android_asset/public" + source);
                InputStream is = protocolHandler.openAsset("public" + source);
                tempSource = new File(getActivity().getCacheDir().getAbsolutePath() + f.getName());
                FileOutputStream os = new FileOutputStream(tempSource);
                IOUtils.copy(is, os);
                os.close();
            } else {
                if (source.startsWith("file:")) {
                    Uri uri = Uri.parse(source);
                    tempSource = new File(uri.getPath());
                } else {
                    tempSource = new File(source);
                }
            }

            saveCall(call);

            UCrop.of(
                    Uri.fromFile(tempSource),
                    Uri.fromFile(dest)
            )
                    .withAspectRatio(1, 1)
                    .withMaxResultSize(width, height)
                    .start(getActivity());

        } catch (IOException e) {
            call.reject(e.getLocalizedMessage());
        }

    }
}
