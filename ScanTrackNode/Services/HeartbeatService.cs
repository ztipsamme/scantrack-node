using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScanTrackNode.Services
{
    public class HeartbeatService : BackgroundService
    {
        private readonly NodeRegistry _registry;
        private readonly ILogger<HeartbeatService> _logger;

        public HeartbeatService(NodeRegistry registry, ILogger<HeartbeatService> logger)
        {
            _registry = registry;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(1), ct);
                // skicka POST /nodes till registret

                _logger.LogInformation("Skickar heartbeat...");
                await _registry.RegisterSelfAsync();
            }
        }
    }
}