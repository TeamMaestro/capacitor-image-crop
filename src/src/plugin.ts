import { Plugins } from '@capacitor/core';
import { IImageCrop } from './index';

const { ImageCropPlugin } = Plugins;

export class ImageCrop implements IImageCrop {
  show(options: {
    source:string;
    width?: number;
    height?: number;
    ratio?:string;
    lock?:boolean;
  }): Promise<{ value: string }> {
    return ImageCropPlugin.show(options);
  }
}
