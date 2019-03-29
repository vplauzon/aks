using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace CpuRamRequestApi.Controllers
{
    [Route("/")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        //  GET /
        [HttpGet]
        public async Task<ActionResult<object>> GetAsync(
            [FromQuery]int duration = 1,
            [FromQuery]int core = 1,
            [FromQuery]int ram = 10)
        {
            try
            {
                core = Math.Max(core, 1);
                core = Math.Min(core, 256);
                ram = Math.Max(1, ram);
                ram = Math.Min(10000, ram);
                duration = Math.Max(duration, 1);
                duration = Math.Min(duration, 300);

                var source = new CancellationTokenSource(TimeSpan.FromSeconds(duration));
                var cancellationToken = source.Token;
                var stopWatch = Stopwatch.StartNew();
                var tasks = (from i in Enumerable.Range(0, core)
                             let task = Task.Run(() => BusyWork(ram, cancellationToken), cancellationToken)
                             select task).ToArray();

                await Task.WhenAll(tasks);

                return new
                {
                    duration = duration,
                    numberOfCore = core,
                    ram = ram,
                    realDuration = stopWatch.Elapsed
                };
            }
            catch (AggregateException ex)
            {
                var messages = from e in ex.InnerExceptions
                               select e.Message;

                return new
                {
                    exceptions = messages.ToArray()
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    exception = ex.Message
                };
            }
        }

        private void BusyWork(int ram, CancellationToken cancellationToken)
        {
            var ramChunk = new byte[ram * 1024 * 1024];
            var random = new Random();
            int i = 0;

            while (!cancellationToken.IsCancellationRequested)
            {
                ramChunk[i] = (byte)random.Next(0, 255);
                ++i;
                if (i >= ramChunk.Length)
                {
                    i = 0;
                }
            }
        }
    }
}