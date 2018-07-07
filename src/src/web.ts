import { WebPlugin } from '@capacitor/core';
import { IImageCrop } from './definitions';

export class ImageCropPluginWeb extends WebPlugin implements IImageCrop {
  constructor() {
    super({
      name: 'ImageCropPlugin',
      platforms: ['web']
    });
  }

  show(options: {
    source:string;
    width?: number;
    height?: number;
    ratio?:string;
    lock?:boolean;
  }): Promise<{ value: string }> {
    return new Promise(()=>{
      console.log(options);
    });
  }
}

const ImageCropPlugin = new ImageCropPluginWeb();

export { ImageCropPlugin };
