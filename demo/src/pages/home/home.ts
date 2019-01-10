import { Component } from '@angular/core';
import { NavController } from 'ionic-angular';
import { ImageCrop } from 'capacitor-image-crop';
import { CameraResultType, Plugins } from '@capacitor/core';

const {Camera} = Plugins;

@Component({
  selector: 'page-home',
  templateUrl: 'home.html'
})
export class HomePage {
  cropper: ImageCrop;
  src = '';

  constructor(public navCtrl: NavController) {
    this.cropper = new ImageCrop();
  }

  showCrop() {
    this.cropper
      .show({
        source: '~/assets/imgs/all_might.jpg',
        width: 300,
        height: 300
      })
      .then(v => {
        this.src = v.value;
      });
  }

  async takePhotoAndShowCrop() {
    try {
      await Camera.requestPermissions();
      const result = await Camera.getPhoto({resultType: CameraResultType.Uri});
      const cropped = await this.cropper
        .show({
          source: result.path.replace('file://',''),
          width: 300,
          height: 300
        });
      this.src = cropped.value;
    } catch (e) {

    }
  }
}
