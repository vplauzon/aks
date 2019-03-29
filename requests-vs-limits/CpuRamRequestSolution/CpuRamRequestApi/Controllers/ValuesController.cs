using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace CpuRamRequestApi.Controllers
{
    [Route("/")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        // GET api/values
        [HttpGet]
        public ActionResult<object> Get(
            [FromQuery]int duration = 30,
            [FromQuery]int core = 1,
            [FromQuery]int ram = 10)
        {
            return new
            {
                duration = duration,
                numberOfCore = core,
                ram = ram
            };
        }
    }
}