declare global {
  interface PluginRegistry {
    ImageCropPlugin?: IImageCrop;
  }
}

export interface IImageCrop {
  show(options: {
    source:string;
    width?: number;
    height?: number;
    ratio?:string;
    lock?:boolean;
  }): Promise<{ value: string }>;
}
