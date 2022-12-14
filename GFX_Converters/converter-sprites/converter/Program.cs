using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace converter
{
    class Program
    {        
        static void Main(string[] args)
        {

            //sppeccy pal
            Color[] speccyPallete = { Color.FromArgb(0, 0, 0), Color.FromArgb(0, 0, 0xff), Color.FromArgb(0xff, 0, 0), Color.FromArgb(0xff, 0, 0xff), Color.FromArgb(0, 0xff, 0), Color.FromArgb(0, 0xff, 0xff), Color.FromArgb(0xff, 0xff, 0), Color.FromArgb(0xff, 0xff, 0xff) };


            //args[0] = "sprite.png";
            //import texture to array
             Bitmap inputBitmap = new Bitmap(args[0]);
            //            Bitmap inputBitmap = new Bitmap("sprite.png");


            
            int frameWidth = 5;

            if (inputBitmap.Width % 11 == 0)
            {
                frameWidth = 11;
            }

            //calculate frames number
            int totalFrames = inputBitmap.Width / frameWidth;


            for (int frame = 0; frame < totalFrames; frame++)
            {

                byte[] bytes;

               
                int cnt = 0;
                //create tmp bitmap with clean right collumn from source
                Bitmap bitmap = new Bitmap(inputBitmap, frameWidth + 1, inputBitmap.Height);
             
                Color colorTransparent = Color.FromArgb(10, 10, 10);

                //copy pixels from input to new
                for (int x = 0; x < frameWidth; x++)
                    for (int y = 0; y < inputBitmap.Height; y++)
                    {
                        bitmap.SetPixel(x, y, inputBitmap.GetPixel(x+frameWidth*frame, y));
                        //fill right collumn with transparent color
                        bitmap.SetPixel(frameWidth, y, colorTransparent);
                    }

                int size = bitmap.Height * bitmap.Width;


                bytes = new byte[bitmap.Width * bitmap.Height * 2];

                //one frame then simple

                // pop bc       ; берём маску в с и уплотненный байтик в b
                // ld a, (hl)   ; берём байт с экарана
                // and c        ; накладываем маску
                // or b         ; орим
                // ld(hl), a    ;кладем в экран

                //формат спрайта байт маски, байт уплотненных данных

                for (int y = 0; y < bitmap.Height; y++)
                    for (int x = 0; x < bitmap.Width / 2; x++)
                    {
                        //всё оставляем по умолчанию
                        byte mask = 0b11111111;
                        //уплотненный цвет инк паппер - по сути атрибут
                        byte color = 0b00000000;//чистый
                                                //grab 2 pixels
                        Color colorLeft = bitmap.GetPixel(x * 2, y);
                        Color colorRight = bitmap.GetPixel(x * 2 + 1, y);
                        //grab 2 color index
                        int colorIndexLeft = Array.IndexOf(speccyPallete, colorLeft);
                        int colorIndexRight = Array.IndexOf(speccyPallete, colorRight);

                        //enable mask for paper
                        if (colorIndexRight >= 0)
                        {
                            mask = (byte)(mask & 0b00000111);
                            color = (byte)(color + colorIndexRight << 3);
                        }
                        //enable mask for ink
                        if (colorIndexLeft >= 0)
                        {
                            mask = (byte)(mask & 0b00111000);
                            color = (byte)(color + colorIndexLeft);
                        }

                        bytes[cnt] = mask;
                        bytes[cnt + 1] = (byte)(color + 64);
                        cnt += 2;
                    }

                //shifted

                for (int y = 0; y < bitmap.Height; y++)
                    for (int x = 0; x < bitmap.Width / 2; x++)
                    {

                        //всё оставляем по умолчанию
                        byte mask = 0b11111111;
                        //уплотненный цвет инк паппер - по сути атрибут
                        byte color = 0b00000000;//чистый
                                                //grab 2 pixels

                        int colorIndexLeft = -1;
                        int colorIndexRight = -1;


                        if (x > 0)
                        {
                            Color colorLeft = bitmap.GetPixel(x * 2 - 1, y);

                            //grab 2 color index
                            colorIndexLeft = Array.IndexOf(speccyPallete, colorLeft);

                        }

                        Color colorRight = bitmap.GetPixel(x * 2, y);
                        colorIndexRight = Array.IndexOf(speccyPallete, colorRight);

                        //enable mask for paper
                        if (colorIndexRight >= 0)
                        {
                            mask = (byte)(mask & 0b00000111);
                            color = (byte)(color + colorIndexRight << 3);
                        }
                        //enable mask for ink
                        if (colorIndexLeft >= 0)
                        {
                            mask = (byte)(mask & 0b00111000);
                            color = (byte)(color + colorIndexLeft);
                        }

                        bytes[cnt] = mask;
                        bytes[cnt + 1] = (byte)(color + 64);
                        cnt += 2;
                    }


                if (frame == 0)
                    System.IO.File.WriteAllBytes(args[0] + ".bin", bytes);
                else
                    AppendAllBytes(args[0] + ".bin", bytes);



            }





        }


        public static void AppendAllBytes(string path, byte[] bytes)
        {
            //argument-checking here.

            using (var stream = new System.IO.FileStream(path, System.IO.FileMode.Append))
            {
                stream.Write(bytes, 0, bytes.Length);
            }
        }


    }

  
}
