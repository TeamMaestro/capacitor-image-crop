import { Component } from '@angular/core';
import { NavController } from 'ionic-angular';
import { ImageCrop } from 'capacitor-image-crop';
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
}
