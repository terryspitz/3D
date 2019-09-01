
//pick one shape:
//shape = "reuleaux";
//shape = "triangle";
shape = "ellipse";

minor_radius = 0.5; // mm
major_radius = 9.0 + minor_radius; // mm
z_scale = 2; // ratio of z height to minor axis diameter
twists = 2; //number of times the cross-section twists as it goes round the ring, fractional twists are possible for cross-sectional shapes with rotational symmetry.

function torus(az, theta) = let (
    // A torus with chosen cross-section: 
    // See https://en.wikipedia.org/wiki/Reuleaux_triangle.
    //
    //Args:
    //    az: azimuth: angle around major axis in degrees
    //    theta: [0,360] angle around minor axis in degrees
    
    mod_theta = theta % 120 - 60,
    cos_theta = cos(mod_theta),
    twist = az*twists,
    
    // Use Polar equation of a circle from https://en.wikipedia.org/wiki/Polar_coordinate_system#Circle
    // R=1, r0=1/sqrt(3) (2/3 height of unit sided equilateral triangle, offset of centre of reuleaux arc)
    r_reuleaux = (sqrt(4/3*cos_theta*cos_theta + 8/3) - 2/sqrt(3)*cos_theta)/2,
    degrees = (twist+30) % 120 - 30,
    //echo(twist, degrees),
    r0_reuleaux = (degrees<30) ?
        1-cos(degrees)/sqrt(3) + 0.5
        : cos(degrees-60)/sqrt(3) + 0.5,
    
    // or triange cross-section:
    r_triangle = 1/cos_theta/6,
    r0_triangle = 0,
    
    // or ellipse:
    eccentricity= 0.8,
    r_ellipse =  1/(1 + eccentricity * cos(theta)),
    r0_ellipse = -(1 + cos(az*twists)/eccentricity/eccentricity),
    
    r = shape=="reuleaux" ? r_reuleaux : shape=="triangle" ? r_triangle : shape=="ellipse" ? r_ellipse : error,
    r0 = shape=="reuleaux"  ? r0_reuleaux : shape=="triangle" ? r0_triangle : shape=="ellipse" ? r0_ellipse : error,
    
    theta2 = theta + twist,  //twist it!
    //based on parametric equation of a torus
    full_radius = major_radius + minor_radius * (r * cos(theta2) - r0),
    x = sin(az) * full_radius,
    y = cos(az) * full_radius,
    z = r * sin(theta2) * minor_radius * z_scale
    ) 
    [x, y, z];
    

az_step = 3.6;
theta_step = 10;
plot_3D = 1;
//for debugging, show slices of the surface
zebra = 1;  //use 1 for continuous, 2 to skip alternating slices, higher to skip more
if(plot_3D) {
    polyhedron(points = [
        for(az = [0:az_step*zebra:360-1], theta = [0:theta_step:360-1])
            each let(
                p0 = torus(az, theta),
                p1 = torus(az+az_step, theta),
                p2 = torus(az+az_step, theta+theta_step),
                p3 = torus(az, theta+theta_step)
            ) [p0, p1, p2, p3]
        ],
        
        faces =  [for (i = [0:360/az_step*120/theta_step *3]) each
                        [[i*4,i*4+1,i*4+2], [i*4+2,i*4+3,i*4]]
        ]
    );
}
else //2D render
{
    for(az=[0:36: 360]) {
        translate([0, 0, az/36])
        polygon(points = [
            for(theta = [0:theta_step:360-1])
                each let(
                    p0 = reuleaux(az, theta)
                ) [[p0[1], p0[2]]]  // pick y and z
            ]
        );
    }
}