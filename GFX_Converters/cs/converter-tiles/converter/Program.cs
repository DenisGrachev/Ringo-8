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

            //import texture to array
             Bitmap inputBitmap = new Bitmap(args[0]);
            //Bitmap bitmap = new Bitmap("tile2.png");


            //copy input to new
            int tileNum = 0;

            //create tmp bitmap with clean left 4 pixels
            Bitmap bitmap = new Bitmap(inputBitmap, 12, 8);

            Color colorBlack = Color.FromArgb(0, 0, 0);
             for (int x = 0; x < 12; x++)
                for (int y = 0; y < 8; y++)
                {
                    bitmap.SetPixel(x, y, colorBlack);
                }


            //get every tile from tileset

            int tilesX = inputBitmap.Width / 8;
            int tilesY = inputBitmap.Height / 8;

            for (int ty = 0; ty < tilesY; ty++)
                for (int tx = 0; tx < tilesX; tx++)
                {

                    #region one tile generate

                    //copy pixels from input to new
                    for (int x = 0; x < 8; x++)
                        for (int y = 0; y < 8; y++)
                        {
                            bitmap.SetPixel(x + 4, y, inputBitmap.GetPixel(x + 8 * tx, y+8*ty));
                        }


                    byte[] bytes;// = new byte[bitmap.Width * bitmap.Height*2];                        

                    int cnt = 0;

                    int size = bitmap.Height * bitmap.Width;


                    bytes = new byte[(bitmap.Width * bitmap.Height) / 2];

                    //6 bytes per tile line

                    for (int y = 0; y < bitmap.Height; y++)
                    {

                        for (int x = 0; x < 6; x++)
                        {

                            //original
                            Color color = bitmap.GetPixel(x * 2, y);

                            for (int i = 0; i < 8; i++)
                            {
                                if (color == speccyPallete[i])
                                {
                                    bytes[cnt] = (byte)(i + 64);
                                }
                            }

                            color = bitmap.GetPixel(x * 2 + 1, y);

                            for (int i = 0; i < 8; i++)
                            {
                                if (color == speccyPallete[i])
                                {
                                    bytes[cnt] += (byte)(i * 8);
                                }
                            }


                            cnt++;
                        }


                    }
                    #endregion




                    if (tileNum == 0)
                        System.IO.File.WriteAllBytes(args[0] + ".bin", bytes);
                     else
                       AppendAllBytes(args[0] + ".bin", bytes);

                    tileNum++;
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
