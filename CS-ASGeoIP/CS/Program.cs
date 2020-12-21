using System;
using System.IO;
using System.Net;
using System.Text;
using System.Runtime.InteropServices;

namespace TxTGeoIP
{
    class Program
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr _lopen(string lpPathName, int iReadWrite);

        [DllImport("kernel32.dll")]
        public static extern bool CloseHandle(IntPtr hObject);

        public const int OF_READWRITE = 2;
        public const int OF_SHARE_DENY_NONE = 0x40;
        public static readonly IntPtr HFILE_ERROR = new IntPtr(-1);

        static void Main(string[] args)
        {
            //骚气的标题
            Console.Title = "[" + DateTime.Now.ToShortDateString().ToString() + "]" + "Sven-Coop CS-AS GeoIp";

            //监视文件
            FileSystemWatcher fsw = new FileSystemWatcher();
            //获取程序路径
            fsw.Path = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            //获取或设置要监视的更改类型
            fsw.NotifyFilter = NotifyFilters.LastWrite  | NotifyFilters.Size;
            //要监视的文件
            fsw.Filter = "IPInput.txt";
            //设置是否级联监视指定路径中的子目录
            fsw.IncludeSubdirectories = false;
            //添加事件
            fsw.Changed += OnChanged;
            // 开始监听
            fsw.EnableRaisingEvents = true;
            //退出
            Console.WriteLine("按q退出！");
            while (Console.Read() != 'q') ;
            //日志输出好看一点
            void Dialog(in string szInput)
            {

                Console.Write("==>[" +DateTime.Now.ToString() + "]  " + szInput + ".\r\n");
            }
            //改变时
            void OnChanged(object source, FileSystemEventArgs e)
            {
                Dialog(e.Name + "文件被改变,开始查找IP库");
                Writer(GeoIt(ReadIt(e.FullPath).Split(',')[1].Split(':')[0]), ReadIt(e.FullPath).Split(',')[0]);
            }
            //写
            void Writer(in string output, in string ID)
            {
                if(string.IsNullOrEmpty(output) || string.IsNullOrEmpty(ID))
                {
                    Dialog("空白IP,不写出");
                    return;
                }
                string outPath = AppDomain.CurrentDomain.SetupInformation.ApplicationBase + "IPOutput.txt";
                if (!IsFileInUse(outPath))
                {
                    StreamReader sr = new StreamReader(outPath, Encoding.UTF8);
                    string str;
                    bool IsExs = false;
                    //开始读取
                    str = sr.ReadToEnd();
                    //关闭流
                    sr.Close();

                    string[]cache = str.Split('\n');
                    for(int i =0;i< cache.Length;i++)
                    {
                        string[] zj = cache[i].Split(',');
                        if (zj[0] == ID)
                        {
                            cache[i] = ID + "," + FormatIpBack(output);
                            IsExs = true;
                        }
                    }

                    string op = "";
                    for (int i = 0; i < cache.Length; i++)
                    {
                        if(!string.IsNullOrEmpty(cache[i]))
                            op = op + cache[i] + "\n";
                    }
                    if (!IsExs)
                        op = op + ID + "," + FormatIpBack(output);

                    FileStream fs = new FileStream(outPath, FileMode.Create);
                    StreamWriter sw = new StreamWriter(fs);
                    //开始写入
                    sw.Write(op);
                    //清空缓冲区
                    sw.Flush();
                    //关闭流
                    sw.Close();
                    fs.Close();
                    Dialog("写入成功！");
                }
                else
                    Dialog("被占用，不写入");
            }
            //规范格式
            string FormatIpBack(in string Input)
            {
                try
                {
                    string[] cache = Input.Replace("{", "").Replace("}", "").Replace('"', ' ').Replace(" ", "").Split(',');
                    string[] Output = new string[4];
                    for (int i = 0; i < cache.Length; i++)
                    {
                        if (cache[i].IndexOf("countryCode") != -1)
                            Output[0] = cache[i].Replace("countryCode:", "");
                        else if (cache[i].IndexOf("country") != -1)
                            Output[1] = cache[i].Replace("country:", "");
                        else if (cache[i].IndexOf("regionName") != -1)
                            Output[2] = cache[i].Replace("regionName:", "");
                        else if (cache[i].IndexOf("city") != -1)
                            Output[3] = cache[i].Replace("city:", "");
                    }
                    return Output[0] + "," + Output[1] + "," + Output[2] + "," + Output[3];
                }
                catch(Exception e)
                {
                    Dialog("[[[错误]]]:" + e.Message);
                }
                return "";
            }

            //读
            string ReadIt(in string GeoFile)
            {
                if (!IsFileInUse(GeoFile))
                {
                    try
                    {
                        StreamReader sr = new StreamReader(GeoFile, Encoding.Default);
                        //开始读取
                        String line = sr.ReadToEnd();
                        //关闭流
                        sr.Close();
                        Dialog("正在向服务器发送地址: " + line.Split(',')[1]+"("+ line.Split(',')[0] + ")...");
                        //去分隔符
                        return line;
                    }
                    catch(Exception e)
                    {
                        Dialog("被占用发送失败咯:" + e.Message);
                        return null;
                    }

                }
                else return null;
            }

            string GeoIt(in string ipAdd)
            {
                if(string.IsNullOrEmpty(ipAdd))
                {
                    Dialog("空白ip,不获取地址");
                    return "";
                }
                //发送地址
                string url = "http://ip-api.com/json/" + ipAdd  + "?lang=zh-CN";
                string str = "";
                WebRequest wRequest = WebRequest.Create(url);
                wRequest.Method = "GET";
                wRequest.ContentType = "text/html;charset=UTF-8";
                wRequest.Timeout = 50000; //设置超时时间
                WebResponse wResponse = null;
                try
                {
                    wResponse = wRequest.GetResponse();
                }
                catch (WebException e)
                {
                    //发生网络错误时,获取错误响应信息
                    Dialog("发生网络错误！ " + e.Message + ". 请稍后再试");
                }
                catch (Exception e)
                {
                    //发生异常时把错误信息当作错误信息返回
                    Dialog("发生错误：" + e.Message);

                }
                finally
                {
                    if (wResponse != null)
                    {
                        //获得网络响应流
                        Stream stream = wResponse.GetResponseStream();
                        //防中文乱码
                        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("utf-8"));
                        //url返回的值  
                        str = reader.ReadToEnd();
                        //关闭流
                        reader.Close();
                        wResponse.Close();
                        Dialog("成功！获取了地址！");
                    }
                   else
                        Dialog("响应为空！");
                }
                return str;
            }
            //占用判断防止报错
            bool IsFileInUse(in string fileName)
            {
                IntPtr vHandle = _lopen(fileName, OF_READWRITE | OF_SHARE_DENY_NONE);
                CloseHandle(vHandle);
                return vHandle == HFILE_ERROR ? true : false;
            }
        }
    }
}
